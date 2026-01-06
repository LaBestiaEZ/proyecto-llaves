import { Component, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { OrderService } from '../../services/order.service';
import { Order } from '../../models/shop.models';
import { LoadingSpinnerComponent } from '../../shared/components/loading-spinner/loading-spinner.component';

@Component({
  selector: 'app-admin-orders',
  standalone: true,
  imports: [CommonModule, FormsModule, LoadingSpinnerComponent],
  templateUrl: './admin-orders.component.html'
})
export class AdminOrdersComponent implements OnInit {
  orders = signal<Order[]>([]);
  loading = signal(true);

  constructor(private orderService: OrderService) { }

  parseFloat(value: string): number {
    return parseFloat(value);
  }

  ngOnInit(): void {
    this.loadOrders();
  }

  loadOrders(): void {
    console.log('Loading orders...');
    this.loading.set(true);
    this.orderService.getAll().subscribe({
      next: (response) => {
        console.log('Orders response:', response);
        this.orders.set(response.member);
        this.loading.set(false);
      },
      error: (err) => {
        console.error('Error loading orders:', err);
        console.error('Error status:', err.status);
        console.error('Error message:', err.message);
        alert(`Error al cargar pedidos: ${err.message || 'Error desconocido'}`);
        this.loading.set(false);
      }
    });
  }

  updateStatus(order: Order): void {
    this.orderService.updateStatus(order.id!, order.status).subscribe({
      next: () => {
        alert('Estado actualizado correctamente');
      },
      error: (err) => {
        alert('Error al actualizar estado');
        console.error(err);
        this.loadOrders(); // Recargar para revertir cambio
      }
    });
  }

  deleteOrder(id: number): void {
    if (confirm('¿Estás seguro de eliminar este pedido? Esta acción no se puede deshacer.')) {
      this.orderService.delete(id).subscribe({
        next: () => {
          this.loadOrders();
        },
        error: (err) => {
          alert('Error al eliminar pedido');
          console.error(err);
        }
      });
    }
  }

  getStatusClass(status: string): string {
    const classes: any = {
      'pending': 'bg-yellow-50 border-yellow-300',
      'confirmed': 'bg-blue-50 border-blue-300',
      'shipped': 'bg-purple-50 border-purple-300',
      'completed': 'bg-green-50 border-green-300',
      'cancelled': 'bg-red-50 border-red-300'
    };
    return classes[status] || '';
  }
}
