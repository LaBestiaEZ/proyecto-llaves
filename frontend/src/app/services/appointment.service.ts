import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { environment } from '../../environments/environment';
import { Appointment } from '../models/shop.models';

interface AppointmentResponse {
  member: Appointment[];
  totalItems: number;
}

@Injectable({
  providedIn: 'root'
})
export class AppointmentService {
  private http = inject(HttpClient);
  private apiUrl = `${environment.apiUrl}/appointments`;

  getAppointments(): Observable<Appointment[]> {
    return this.http.get<AppointmentResponse>(this.apiUrl).pipe(
      map(response => response['member'] || [])
    );
  }

  getMyAppointments(): Observable<Appointment[]> {
    return this.http.get<AppointmentResponse>(this.apiUrl).pipe(
      map(response => response['member'] || [])
    );
  }

  getAppointment(id: number): Observable<Appointment> {
    return this.http.get<Appointment>(`${this.apiUrl}/${id}`);
  }

  createAppointment(appointment: Partial<Appointment>): Observable<Appointment> {
    return this.http.post<Appointment>(this.apiUrl, appointment, {
      headers: { 'Content-Type': 'application/ld+json' }
    });
  }

  updateAppointment(id: number, appointment: Partial<Appointment>): Observable<Appointment> {
    return this.http.put<Appointment>(`${this.apiUrl}/${id}`, appointment);
  }

  deleteAppointment(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`);
  }
}
