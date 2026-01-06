<?php

namespace App\State;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProcessorInterface;
use App\Entity\Order;
use App\Entity\OrderItem;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\SecurityBundle\Security;
use Symfony\Component\HttpKernel\Exception\BadRequestHttpException;

class OrderProcessor implements ProcessorInterface
{
    public function __construct(
        private EntityManagerInterface $entityManager,
        private Security $security
    ) {
    }

    public function process(mixed $data, Operation $operation, array $uriVariables = [], array $context = []): ?Order
    {
        if (!$data instanceof Order) {
            return $data;
        }

        // Si es una nueva orden
        if ($operation instanceof \ApiPlatform\Metadata\Post) {
            // Asignar usuario actual
            $user = $this->security->getUser();
            $data->setUser($user);

            // PASO 1: Verificar stock de TODOS los productos antes de modificar nada
            $stockErrors = [];
            foreach ($data->getItems() as $item) {
                $product = $item->getProduct();

                if ($item->getQuantity() <= 0) {
                    throw new BadRequestHttpException('La cantidad debe ser mayor que 0');
                }

                if ($product->getStock() < $item->getQuantity()) {
                    $stockErrors[] = sprintf(
                        '%s %s: disponible %d, solicitado %d',
                        $product->getBrand(),
                        $product->getModel(),
                        $product->getStock(),
                        $item->getQuantity()
                    );
                }
            }

            // Si hay errores de stock, lanzar excepción con todos los errores
            if (!empty($stockErrors)) {
                throw new BadRequestHttpException(
                    'Stock insuficiente para los siguientes productos: ' . implode('; ', $stockErrors)
                );
            }

            // PASO 2: Procesar items y actualizar stock
            foreach ($data->getItems() as $item) {
                $product = $item->getProduct();

                // Guardar el precio actual del producto
                $item->setPrice($product->getPrice());

                // Restar del stock
                $product->setStock($product->getStock() - $item->getQuantity());
                $this->entityManager->persist($product);
            }

            // Calcular total
            $data->calculateTotal();
        }

        $this->entityManager->persist($data);
        $this->entityManager->flush();

        return $data;
    }
}
