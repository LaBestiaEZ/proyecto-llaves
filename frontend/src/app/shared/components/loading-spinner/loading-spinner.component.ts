import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
    selector: 'app-loading-spinner',
    standalone: true,
    imports: [CommonModule],
    templateUrl: './loading-spinner.component.html'
})
export class LoadingSpinnerComponent {
    @Input() size: 'sm' | 'md' | 'lg' = 'md';
    @Input() message: string = 'Cargando...';

    get spinnerClass(): string {
        const sizeClasses = {
            'sm': 'spinner-border-sm',
            'md': '',
            'lg': ''
        };
        return sizeClasses[this.size];
    }

    get spinnerStyle(): any {
        if (this.size === 'lg') {
            return { width: '3rem', height: '3rem' };
        }
        return {};
    }
}
