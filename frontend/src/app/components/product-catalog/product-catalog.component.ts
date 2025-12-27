import { Component, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ProductService } from '../../services/product.service';
import { CartService } from '../../services/cart.service';
import { Product } from '../../models/shop.models';
import { RouterLink } from '@angular/router';

@Component({
  selector: 'app-product-catalog',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './product-catalog.component.html'
})
export class ProductCatalogComponent implements OnInit {
  products = signal<Product[]>([]);
  loading = signal(true);
  error = signal('');

  constructor(
    private productService: ProductService,
    public cartService: CartService
  ) {}

  ngOnInit(): void {
    this.loadProducts();
  }

  loadProducts(): void {
    this.productService.getAll().subscribe({
      next: (response) => {
        this.products.set(response.member);
        this.loading.set(false);
      },
      error: (err) => {
        this.error.set('Error al cargar productos');
        this.loading.set(false);
        console.error(err);
      }
    });
  }

  addToCart(product: Product): void {
    this.cartService.addItem(product, 1);
  }
}
