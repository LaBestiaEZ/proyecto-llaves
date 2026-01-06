import { Component, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink, Router } from '@angular/router';
import { CartService } from '../../services/cart.service';
import { OrderService } from '../../services/order.service';
import { AuthService } from '../../services/auth.service';
import { CreateOrderDTO } from '../../models/shop.models';

@Component({
  selector: 'app-cart',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './cart.component.html'
})
export class CartComponent {
  processing = signal(false);
  orderMessage = signal('');
  orderSuccess = signal(false);

  constructor(
    public cartService: CartService,
    private orderService: OrderService,
    private authService: AuthService,
    private router: Router
  ) {}

  updateQuantity(productId: number, quantity: number): void {
    this.cartService.updateQuantity(productId, quantity);
  }

  removeItem(productId: number): void {
    if (confirm('¿Estás seguro de eliminar este producto?')) {
      this.cartService.removeItem(productId);
    }
  }

  clearCart(): void {
    if (confirm('¿Estás seguro de vaciar el carrito?')) {
      this.cartService.clear();
    }
  }

  checkout(): void {
    // Prevenir múltiples clics
    if (this.processing()) {
      return;
    }

    // Verificar si está autenticado
    if (!this.authService.isAuthenticated()) {
      this.router.navigate(['/login'], { queryParams: { returnUrl: '/cart' } });
      return;
    }

    const items = this.cartService.getItems();
    
    if (items.length === 0) {
      alert('El carrito está vacío');
      return;
    }

    const orderDTO: CreateOrderDTO = {
      items: items.map(item => ({
        product: `/api/products/${item.product.id}`,
        quantity: item.quantity
      }))
    };

    // Activar estado de procesamiento
    this.processing.set(true);
    this.orderMessage.set('');

    this.orderService.create(orderDTO).subscribe({
      next: (order) => {
        this.processing.set(false);
        this.orderSuccess.set(true);
        this.orderMessage.set('¡Pedido realizado con éxito! Redirigiendo...');
        this.cartService.clear();
        
        setTimeout(() => {
          this.router.navigate(['/orders']);
        }, 1500);
      },
      error: (err) => {
        this.processing.set(false);
        this.orderSuccess.set(false);
        
        // Obtener mensaje de error más detallado
        let errorMessage = 'Error desconocido';
        
        if (err.error) {
          // API Platform devuelve errores en diferentes formatos
          if (err.error['hydra:description']) {
            errorMessage = err.error['hydra:description'];
          } else if (err.error.message) {
            errorMessage = err.error.message;
          } else if (err.error.detail) {
            errorMessage = err.error.detail;
          } else if (typeof err.error === 'string') {
            errorMessage = err.error;
          }
        } else if (err.message) {
          errorMessage = err.message;
        }
        
        this.orderMessage.set(errorMessage);
        console.error('Error al realizar pedido:', err);
      }
    });
  }
}
