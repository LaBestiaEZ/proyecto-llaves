import { Component, computed } from '@angular/core';
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
  processing = computed(() => false);
  orderMessage = computed(() => '');
  orderSuccess = computed(() => false);

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
    // Verificar si está autenticado
    if (!this.authService.isAuthenticated()) {
      if (confirm('Debes iniciar sesión para realizar un pedido. ¿Deseas ir al login?')) {
        this.router.navigate(['/login'], { queryParams: { returnUrl: '/cart' } });
      }
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

    this.orderService.create(orderDTO).subscribe({
      next: (order) => {
        this.cartService.clear();
        alert('¡Pedido realizado con éxito! ID: ' + order.id);
        this.router.navigate(['/orders']);
      },
      error: (err) => {
        alert('Error al realizar el pedido: ' + (err.error?.message || 'Error desconocido'));
        console.error(err);
      }
    });
  }
}
