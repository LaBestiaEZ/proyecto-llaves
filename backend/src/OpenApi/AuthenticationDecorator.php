<?php

namespace App\OpenApi;

use ApiPlatform\OpenApi\Factory\OpenApiFactoryInterface;
use ApiPlatform\OpenApi\OpenApi;
use ApiPlatform\OpenApi\Model;

final class AuthenticationDecorator implements OpenApiFactoryInterface
{
    public function __construct(
        private OpenApiFactoryInterface $decorated
    ) {}

    public function __invoke(array $context = []): OpenApi
    {
        $openApi = ($this->decorated)($context);
        $paths = $openApi->getPaths();
        $pathsArray = $paths->getPaths();

        // FORZAR: Eliminar completamente el endpoint de login si existe
        unset($pathsArray['/api/auth/login']);

        // Crear el endpoint de login desde cero con el tag correcto
        $loginPath = new Model\PathItem(
            post: new Model\Operation(
                operationId: 'postAuthLogin',
                tags: ['Authentication'],
                summary: 'Iniciar sesión',
                description: 'Autenticar usuario y obtener token JWT + refresh token',
                requestBody: new Model\RequestBody(
                    content: new \ArrayObject([
                        'application/json' => [
                            'schema' => [
                                'type' => 'object',
                                'required' => ['username', 'password'],
                                'properties' => [
                                    'username' => ['type' => 'string', 'format' => 'email', 'example' => 'admin@llaves.com'],
                                    'password' => ['type' => 'string', 'format' => 'password', 'example' => 'admin']
                                ]
                            ]
                        ]
                    ])
                ),
                responses: [
                    '200' => new Model\Response(
                        description: 'Login exitoso',
                        content: new \ArrayObject([
                            'application/json' => [
                                'schema' => [
                                    'type' => 'object',
                                    'properties' => [
                                        'token' => ['type' => 'string', 'description' => 'JWT token (válido 1 hora)'],
                                        'refresh_token' => ['type' => 'string', 'description' => 'Refresh token (válido 30 días)'],
                                        'user' => [
                                            'type' => 'object',
                                            'properties' => [
                                                'id' => ['type' => 'integer'],
                                                'email' => ['type' => 'string'],
                                                'roles' => ['type' => 'array', 'items' => ['type' => 'string']]
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        ])
                    ),
                    '401' => new Model\Response(description: 'Credenciales inválidas')
                ]
            )
        );
        $pathsArray['/api/auth/login'] = $loginPath;

        // Refresh Token
        $refreshPath = new Model\PathItem(
            post: new Model\Operation(
                operationId: 'postAuthRefresh',
                tags: ['Authentication'],
                summary: 'Renovar token JWT',
                description: 'Obtener un nuevo JWT usando un refresh token válido',
                requestBody: new Model\RequestBody(
                    content: new \ArrayObject([
                        'application/json' => [
                            'schema' => [
                                'type' => 'object',
                                'required' => ['refresh_token'],
                                'properties' => [
                                    'refresh_token' => ['type' => 'string', 'description' => 'Refresh token obtenido en el login']
                                ]
                            ]
                        ]
                    ])
                ),
                responses: [
                    '200' => new Model\Response(
                        description: 'Token renovado exitosamente',
                        content: new \ArrayObject([
                            'application/json' => [
                                'schema' => [
                                    'type' => 'object',
                                    'properties' => [
                                        'token' => ['type' => 'string', 'description' => 'Nuevo JWT token'],
                                        'refresh_token' => ['type' => 'string', 'description' => 'Mismo refresh token'],
                                        'user' => [
                                            'type' => 'object',
                                            'properties' => [
                                                'id' => ['type' => 'integer'],
                                                'email' => ['type' => 'string'],
                                                'roles' => ['type' => 'array', 'items' => ['type' => 'string']]
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        ])
                    ),
                    '401' => new Model\Response(description: 'Refresh token inválido o expirado')
                ]
            )
        );
        $pathsArray['/api/auth/refresh'] = $refreshPath;

        // Reconstruir el objeto Paths con todos los endpoints
        $newPaths = new Model\Paths();
        foreach ($pathsArray as $path => $pathItem) {
            $newPaths->addPath($path, $pathItem);
        }

        return $openApi->withPaths($newPaths);
    }
}
