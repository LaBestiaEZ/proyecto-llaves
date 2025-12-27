export interface Product {
  id?: number;
  brand: string;
  model: string;
  year: number;
  price: string;
  stock: number;
  description?: string;
  imageUrl?: string;
  createdAt?: string;
  updatedAt?: string;
}

export interface CartItem {
  product: Product;
  quantity: number;
}

export interface OrderItem {
  id?: number;
  product: Product;
  quantity: number;
  price: string;
}

export interface Order {
  id?: number;
  user?: any;
  items: OrderItem[];
  total: string;
  status: 'pending' | 'confirmed' | 'shipped' | 'completed' | 'cancelled';
  createdAt?: string;
  updatedAt?: string;
}

export interface CreateOrderDTO {
  items: {
    product: string; // IRI del producto
    quantity: number;
  }[];
}
