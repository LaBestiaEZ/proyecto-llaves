<?php

namespace App\State;

use ApiPlatform\Metadata\Operation;
use ApiPlatform\State\ProcessorInterface;
use App\Entity\User;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\HttpKernel\Exception\ConflictHttpException;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;

/**
 * State Processor para el registro de usuarios.
 * Maneja el hash de contraseña y la validación de email duplicado.
 */
class UserRegistrationProcessor implements ProcessorInterface
{
    public function __construct(
        private EntityManagerInterface $entityManager,
        private UserPasswordHasherInterface $passwordHasher,
        private ProcessorInterface $persistProcessor
    ) {
    }

    /**
     * @param User $data
     */
    public function process(mixed $data, Operation $operation, array $uriVariables = [], array $context = []): User
    {
        // Verificar si el email ya existe
        $existingUser = $this->entityManager->getRepository(User::class)->findOneBy(['email' => $data->getEmail()]);
        if ($existingUser) {
            throw new ConflictHttpException('Este email ya está registrado');
        }

        // Hash de la contraseña
        $hashedPassword = $this->passwordHasher->hashPassword($data, $data->getPassword());
        $data->setPassword($hashedPassword);

        // Asegurar que tiene el rol ROLE_USER
        if (empty($data->getRoles()) || !in_array('ROLE_USER', $data->getRoles())) {
            $data->setRoles(['ROLE_USER']);
        }

        // Persistir usando el processor por defecto
        return $this->persistProcessor->process($data, $operation, $uriVariables, $context);
    }
}
