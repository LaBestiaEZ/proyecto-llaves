import { Component, inject, signal, OnInit, effect } from '@angular/core';
import { Router } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { AppointmentService } from '../../services/appointment.service';
import { AuthService } from '../../services/auth.service';
import { Appointment } from '../../models/shop.models';

@Component({
  selector: 'app-appointment',
  standalone: true,
  imports: [FormsModule],
  templateUrl: './appointment.component.html'
})
export class AppointmentComponent implements OnInit {
  private appointmentService = inject(AppointmentService);
  private authService = inject(AuthService);
  router = inject(Router);

  appointment = signal<Partial<Appointment>>({
    customerName: '',
    customerEmail: '',
    customerPhone: '',
    appointmentDate: '',
    serviceAddress: '',
    vehicleMake: '',
    vehicleModel: '',
    vehicleYear: '',
    serviceType: 'key_duplication',
    notes: ''
  });

  isSubmitting = signal(false);
  errorMessage = signal('');
  successMessage = signal('');

  serviceTypes = [
    { value: 'key_duplication', label: 'Duplicado de Llave' },
    { value: 'key_programming', label: 'Programación de Llave' },
    { value: 'remote_programming', label: 'Programación de Control Remoto' },
    { value: 'transponder_key', label: 'Llave con Transponder' },
    { value: 'smart_key', label: 'Llave Inteligente' },
    { value: 'key_extraction', label: 'Extracción de Llave Rota' },
    { value: 'emergency_opening', label: 'Apertura de Emergencia' },
    { value: 'other', label: 'Otro' }
  ];

  ngOnInit() {
    if (!this.authService.isAuthenticated()) {
      this.router.navigate(['/login']);
    }
  }

  updateField(field: keyof Appointment, value: any) {
    this.appointment.update(app => ({ ...app, [field]: value }));
  }

  handleInputChange(event: Event, field: keyof Appointment) {
    const value = (event.target as HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement).value;
    this.updateField(field, value);
  }

  submitAppointment() {
    this.isSubmitting.set(true);
    this.errorMessage.set('');
    this.successMessage.set('');

    // Convertir fecha local a formato ISO para la API
    const appointmentData = {
      ...this.appointment(),
      appointmentDate: new Date(this.appointment().appointmentDate!).toISOString()
    };

    this.appointmentService.createAppointment(appointmentData).subscribe({
      next: (response) => {
        this.isSubmitting.set(false);
        this.successMessage.set('¡Cita agendada exitosamente! Te contactaremos pronto.');
        setTimeout(() => {
          this.router.navigate(['/my-appointments']);
        }, 2000);
      },
      error: (err) => {
        this.isSubmitting.set(false);
        this.errorMessage.set('Error al agendar la cita. Por favor intenta nuevamente.');
        console.error('Error creating appointment:', err);
      }
    });
  }
}
