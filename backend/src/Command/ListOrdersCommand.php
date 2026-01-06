<?php

namespace App\Command;

use App\Repository\OrderRepository;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Style\SymfonyStyle;

#[AsCommand(
    name: 'app:list-orders',
    description: 'Lista todos los pedidos',
)]
class ListOrdersCommand extends Command
{
    public function __construct(
        private OrderRepository $orderRepository
    ) {
        parent::__construct();
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $io = new SymfonyStyle($input, $output);
        
        $orders = $this->orderRepository->findAll();
        
        if (empty($orders)) {
            $io->warning('No hay pedidos en la base de datos');
            return Command::SUCCESS;
        }

        $io->title('Lista de Pedidos');
        
        foreach ($orders as $order) {
            $io->section(sprintf('Pedido #%d - Estado: %s - Total: %s€', 
                $order->getId(), 
                $order->getStatus(), 
                $order->getTotal()
            ));
            
            foreach ($order->getItems() as $item) {
                $product = $item->getProduct();
                $io->writeln(sprintf(
                    '  - %s %s: %d unidades (Stock actual: %d)',
                    $product->getBrand(),
                    $product->getModel(),
                    $item->getQuantity(),
                    $product->getStock()
                ));
            }
        }

        return Command::SUCCESS;
    }
}
