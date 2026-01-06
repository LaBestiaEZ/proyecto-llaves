import { Component, inject, OnInit, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { FaqService } from '../../services/faq.service';
import { Faq } from '../../models/shop.models';
import { LoadingSpinnerComponent } from '../../shared/components/loading-spinner/loading-spinner.component';

@Component({
  selector: 'app-admin-faqs',
  standalone: true,
  imports: [FormsModule, LoadingSpinnerComponent],
  templateUrl: './admin-faqs.component.html'
})
export class AdminFaqsComponent implements OnInit {
  private faqService = inject(FaqService);

  faqs = signal<Faq[]>([]);
  loading = signal(true);
  isEditing = signal(false);
  currentFaq = signal<Partial<Faq>>({
    question: '',
    answer: '',
    position: 0,
    active: true
  });

  ngOnInit() {
    this.loadFaqs();
  }

  loadFaqs() {
    this.loading.set(true);
    this.faqService.getFaqs().subscribe({
      next: (faqs) => {
        this.faqs.set(faqs);
        this.loading.set(false);
      },
      error: (err) => {
        console.error('Error loading FAQs:', err);
        this.loading.set(false);
      }
    });
  }

  editFaq(faq: Faq) {
    this.currentFaq.set({ ...faq });
    this.isEditing.set(true);
  }

  resetForm() {
    this.currentFaq.set({
      question: '',
      answer: '',
      position: 0,
      active: true
    });
    this.isEditing.set(false);
  }

  saveFaq() {
    const faq = this.currentFaq();
    if (faq.id) {
      this.faqService.updateFaq(faq.id, faq).subscribe({
        next: () => {
          this.loadFaqs();
          this.resetForm();
        },
        error: (err) => console.error('Error updating FAQ:', err)
      });
    } else {
      this.faqService.createFaq(faq).subscribe({
        next: () => {
          this.loadFaqs();
          this.resetForm();
        },
        error: (err) => console.error('Error creating FAQ:', err)
      });
    }
  }

  deleteFaq(id: number) {
    if (confirm('¿Estás seguro de eliminar esta FAQ?')) {
      this.faqService.deleteFaq(id).subscribe({
        next: () => this.loadFaqs(),
        error: (err) => console.error('Error deleting FAQ:', err)
      });
    }
  }

  updateField(field: keyof Faq, value: any) {
    this.currentFaq.update(faq => ({ ...faq, [field]: value }));
  }

  handleInputChange(event: Event, field: keyof Faq) {
    const value = (event.target as HTMLInputElement | HTMLTextAreaElement).value;
    this.updateField(field, value);
  }

  handleNumberChange(event: Event, field: keyof Faq) {
    const value = +(event.target as HTMLInputElement).value;
    this.updateField(field, value);
  }

  handleCheckboxChange(event: Event, field: keyof Faq) {
    const value = (event.target as HTMLInputElement).checked;
    this.updateField(field, value);
  }
}
