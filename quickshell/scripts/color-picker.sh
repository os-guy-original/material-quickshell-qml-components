#!/bin/bash

# Seçilen rengin saklanacağı dosya
COLOR_FILE="/tmp/hyprpicker-selected-color"

# Hyprpicker ile renk seç (hata mesajlarını çöpe yönlendir)
SELECTED_COLOR=$(hyprpicker --no-fancy -f hex 2>/dev/null)

# Renk seçildi mi kontrol et
if [[ -n "$SELECTED_COLOR" && "$SELECTED_COLOR" =~ ^#[0-9A-Fa-f]{6}$ ]]; then
    # Seçilen rengi dosyaya kaydet
    echo -n "$SELECTED_COLOR" > "$COLOR_FILE"
    
    # Seçilen rengi panoya kopyala
    echo -n "$SELECTED_COLOR" | wl-copy
    
    # Başarı bildirimi göster
    notify-send "Color Picker" "Color $SELECTED_COLOR copied to clipboard" -i color-select
fi 