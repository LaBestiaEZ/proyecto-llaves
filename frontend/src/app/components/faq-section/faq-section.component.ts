import { Component, inject, OnInit, signal, ChangeDetectionStrategy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FaqService } from '../../services/faq.service';
import { Faq } from '../../models/shop.models';

@Component({
  selector: 'app-faq-section',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './faq-section.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class FaqSectionComponent implements OnInit {
  private faqService = inject(FaqService);
  faqs = signal<Faq[]>([]);
  expandedFaq = signal<number | null>(null);
  isLoading = signal(true);

  ngOnInit() {
    console.log('FaqSectionComponent inicializado');
    this.loadFaqs();
  }

  loadFaqs() {
    this.isLoading.set(true);
    console.log('Iniciando carga de FAQs...');
    this.faqService.getActiveFaqs().subscribe({
      next: (faqs) => {
        console.log('FAQs recibidas del servicio:', faqs);
        console.log('Número de FAQs:', faqs ? faqs.length : 0);
        this.faqs.set(faqs || []);
        this.isLoading.set(false);
        console.log('Signal de FAQs actualizado:', this.faqs());
      },
      error: (err) => {
        console.error('Error cargando FAQs:', err);
        this.isLoading.set(false);
      }
    });
  }

  toggleFaq(id: number) {
    this.expandedFaq.set(this.expandedFaq() === id ? null : id);
  }
}
