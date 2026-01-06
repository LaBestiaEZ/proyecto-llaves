<?php

namespace App\EventSubscriber;

use App\Entity\Order;
use Doctrine\Bundle\DoctrineBundle\Attribute\AsDoctrineListener;
use Doctrine\ORM\EntityManagerInterface;
use Doctrine\ORM\Event\PostRemoveEventArgs;
use Doctrine\ORM\Event\PostUpdateEventArgs;
use Doctrine\ORM\Event\PreUpdateEventArgs;
use Doctrine\ORM\Events;

#[AsDoctrineListener(event: Events::preUpdate)]
#[AsDoctrineListener(event: Events::postUpdate)]
#[AsDoctrineListener(event: Events::postRemove)]
class OrderStockSubscriber
{
    private ?string $oldStatus = null;

    public function __construct(
        private EntityManagerInterface $entityManager
    ) {
    }

    /**
     * Capturar el estado anterior antes de la actualización
     */
    public function preUpdate(PreUpdateEventArgs $args): void
    {
        $entity = $args->getObject();

        if (!$entity instanceof Order) {
            return;
        }

        // Guardar el estado anterior
        if ($args->hasChangedField('status')) {
            $this->oldStatus = $args->getOldValue('status');
        }
    }

    /**
     * Después de actualizar, verificar si hay que devolver o descontar stock
     */
    public function postUpdate(PostUpdateEventArgs $args): void
    {
        $entity = $args->getObject();

        if (!$entity instanceof Order) {
            return;
        }

        $newStatus = $entity->getStatus();

        // Si se cancela el pedido y no estaba cancelado antes
        if ($newStatus === Order::STATUS_CANCELLED && $this->oldStatus !== Order::STATUS_CANCELLED) {
            $this->restoreStock($entity);
            $this->entityManager->flush();
        }

        // Si se reactiva un pedido que estaba cancelado, descontar el stock de nuevo
        if ($this->oldStatus === Order::STATUS_CANCELLED && $newStatus !== Order::STATUS_CANCELLED) {
            $this->deductStock($entity);
            $this->entityManager->flush();
        }

        // Resetear el estado guardado
        $this->oldStatus = null;
    }

    /**
     * Cuando se elimina una orden, devolver el stock (solo si no estaba cancelada)
     */
    public function postRemove(PostRemoveEventArgs $args): void
    {
        $entity = $args->getObject();

        if (!$entity instanceof Order) {
            return;
        }

        // Solo restaurar stock si no está cancelado
        if ($entity->getStatus() !== Order::STATUS_CANCELLED) {
            $this->restoreStock($entity);
            $this->entityManager->flush();
        }
    }

    /**
     * Devolver el stock de los productos de una orden
     */
    private function restoreStock(Order $order): void
    {
        foreach ($order->getItems() as $item) {
            $product = $item->getProduct();
            $newStock = $product->getStock() + $item->getQuantity();
            $product->setStock($newStock);
            $this->entityManager->persist($product);
        }
    }

    /**
     * Descontar el stock de los productos de una orden
     */
    private function deductStock(Order $order): void
    {
        foreach ($order->getItems() as $item) {
            $product = $item->getProduct();
            $newStock = $product->getStock() - $item->getQuantity();
            
            // Verificar que no quede en negativo
            if ($newStock < 0) {
                throw new \LogicException(
                    sprintf(
                        'No se puede reactivar el pedido. Stock insuficiente para %s %s',
                        $product->getBrand(),
                        $product->getModel()
                    )
                );
            }
            
            $product->setStock($newStock);
            $this->entityManager->persist($product);
        }
    }
}
