import { Component, OnInit, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ProductService } from '../../services/product.service';
import { CartService } from '../../services/cart.service';
import { Product } from '../../models/shop.models';
import { RouterLink } from '@angular/router';
import { LoadingSpinnerComponent } from '../../shared/components/loading-spinner/loading-spinner.component';

@Component({
  selector: 'app-product-catalog',
  standalone: true,
  imports: [CommonModule, RouterLink, LoadingSpinnerComponent],
  templateUrl: './product-catalog.component.html'
})
export class ProductCatalogComponent implements OnInit {
  allProducts = signal<Product[]>([]);
  searchTerm = signal('');
  selectedBrands = signal<string[]>([]);
  loading = signal(true);
  error = signal('');

  filteredProducts = computed(() => {
    const term = this.searchTerm().toLowerCase();
    const brands = this.selectedBrands();

    return this.allProducts().filter(product => {
      const matchesSearch = !term ||
        product.brand.toLowerCase().includes(term) ||
        product.model.toLowerCase().includes(term) ||
        (product.description?.toLowerCase().includes(term) ?? false);

      const matchesBrand = brands.length === 0 || brands.includes(product.brand);

      return matchesSearch && matchesBrand;
    });
  });

  uniqueBrands = computed(() => {
    const brands = this.allProducts().map(p => p.brand);
    return [...new Set(brands)];
  });

  constructor(
    private productService: ProductService,
    public cartService: CartService
  ) { }

  ngOnInit(): void {
    this.loadProducts();
  }

  loadProducts(): void {
    this.productService.getAll().subscribe({
      next: (response) => {
        this.allProducts.set(response.member);
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

  toggleFilterPanel(): void {
    const filterPanel = document.getElementById('filter-panel1');
    if (filterPanel) {
      filterPanel.style.display = filterPanel.style.display === 'none' ? 'block' : 'none';
    }
  }


  applyFilters(): void {
    const filterPanel = document.getElementById('filter-panel1');
    if (filterPanel) {
      filterPanel.style.display = 'none';

      const checkedFilters = document.querySelectorAll('input[type="checkbox"]:checked');
      const brands = Array.from(checkedFilters).map((checkbox) => checkbox.getAttribute('value') as string);
      this.selectedBrands.set(brands);
    }
  }

  resetFilters(): void {
    const filterPanel = document.getElementById('filter-panel1');
    if (filterPanel) {
      filterPanel.style.display = 'none';
      const checkboxes = filterPanel.querySelectorAll('input[type="checkbox"]');
      checkboxes.forEach((cb: any) => cb.checked = false);
    }
    this.selectedBrands.set([]);
  }

}
