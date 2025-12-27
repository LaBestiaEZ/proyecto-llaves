<?php

namespace App\State;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProcessorInterface;
use App\Entity\Appointment;
use Symfony\Bundle\SecurityBundle\Security;

class AppointmentProcessor implements ProcessorInterface
{
    public function __construct(
        private Security $security
    ) {
    }

    public function process(mixed $data, Operation $operation, array $uriVariables = [], array $context = []): ?Appointment
    {
        if (!$data instanceof Appointment) {
            return $data;
        }

        // Si es una nueva cita
        if ($operation instanceof \ApiPlatform\Metadata\Post) {
            // Asignar usuario actual
            $user = $this->security->getUser();
            if ($user) {
                $data->setUser($user);
            }
        }

        return $data;
    }
}
