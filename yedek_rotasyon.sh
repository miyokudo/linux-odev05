#!/bin/bash
# ==============================================================================
# OKUL: KAPADOKYA ÜNİVERSİTESİ
# DERS: BGY 106 - Linux İşletim Sistemleri (ÖDEV 05)
# GRUP: 1-5
# GRUP ÜYELERİ:
#   25904032 - AGAH ABDULLAH SARSILMAZ
#   25904033 - SAHRA GÜNDOĞDU
#   25904035 - GÖKTUĞ ERDEM PEHLİVAN
#   25904038 - YUNUS EMRE KARAKEÇİLİ
#   25904041 - İSMET HALİT DEMİRCİ
#   25904401 - SALİH DEMİRTAŞ
#   25385901 - AHMAD MUNIR RISHI
# ==============================================================================

# ------------------------------------------------------------------------------
# 9. FONKSİYON KULLANIMI
# ------------------------------------------------------------------------------
baslik_yaz() {
    echo "================================================="
    echo "$1"
    echo "================================================="
}

# ------------------------------------------------------------------------------
# 1. ARGÜMAN KONTROLÜ
# ------------------------------------------------------------------------------
baslik_yaz "1. ARGÜMAN KONTROLÜ"

if [ $# -eq 0 ]; then
    echo "HATA: Dizin girilmedi"
    exit 1
fi

if [ ! -d "$1" ]; then
    echo "HATA: Dizin bulunamadı"
    exit 1
fi

KAYNAK_DIZIN=$(realpath "$1")

# ------------------------------------------------------------------------------
# 2. ÇALIŞMA DİZİNİ HAZIRLAMA
# ------------------------------------------------------------------------------
baslik_yaz "2. ÇALIŞMA DİZİNİ HAZIRLAMA"

YEDEK_DIZIN="$HOME/yedek_deposu"
rm -rf "$YEDEK_DIZIN"
mkdir -p "$YEDEK_DIZIN"
echo "Çalışma dizini hazırlandı: $YEDEK_DIZIN"

# ------------------------------------------------------------------------------
# 3. BELGE DOSYALARINI SAYMA
# ------------------------------------------------------------------------------
baslik_yaz "3. BELGE DOSYALARINI SAYMA"

DOSYA_SAYISI=$(find "$KAYNAK_DIZIN" -type f -name "*.doc" | wc -l)
echo "Toplam belge dosyası: $DOSYA_SAYISI"

# ------------------------------------------------------------------------------
# 4. EN YENİ BELGE DOSYASI
# ------------------------------------------------------------------------------
baslik_yaz "4. EN YENİ BELGE DOSYASI"

if [ "$DOSYA_SAYISI" -gt 0 ]; then
    EN_YENI=$(find "$KAYNAK_DIZIN" -type f -name "*.doc" -printf "%T@ %p\n" | sort -n | tail -1 | cut -d' ' -f2-)

    if [ -n "$EN_YENI" ] && [ -f "$EN_YENI" ]; then
        echo "Dosya: $(basename "$EN_YENI")"
        echo "Boyut: $(du -h "$EN_YENI" | cut -f1)"
    fi
else
    echo "Analiz edilecek .doc dosyası bulunamadı."
fi

# ------------------------------------------------------------------------------
# 5. BOŞ DOSYA ANALİZİ
# ------------------------------------------------------------------------------
baslik_yaz "5. BOŞ DOSYA ANALİZİ"

OZET_DOSYA="$YEDEK_DIZIN/belge_ozeti.txt"
> "$OZET_DOSYA"

if [ "$DOSYA_SAYISI" -gt 0 ]; then
    find "$KAYNAK_DIZIN" -type f -name "*.doc" -print0 | while IFS= read -r -d '' DOSYA
    do
        SATIR=$(wc -l < "$DOSYA")
        echo "$(basename "$DOSYA"): $SATIR satır" >> "$OZET_DOSYA"
    done
    echo "Dosya satır analizleri $OZET_DOSYA adresine kaydedildi."
else
    echo "Analiz edilecek dosya bulunamadı."
fi

# ------------------------------------------------------------------------------
# 6. KOŞULLU DURUM DEĞERLENDİRMESİ
# ------------------------------------------------------------------------------
baslik_yaz "6. KOŞULLU DURUM DEĞERLENDİRMESİ"

if [ "$DOSYA_SAYISI" -lt 30 ]; then
    echo "DURUM: AZ İÇERİK"
else
    echo "DURUM: YETERLİ"
fi

# ------------------------------------------------------------------------------
# 7. ARŞİVLEME
# ------------------------------------------------------------------------------
baslik_yaz "7. ARŞİVLEME"

TARIH=$(date +%Y%m%d)
ARSIV="$YEDEK_DIZIN/belge_yedek_$TARIH.tar.gz"

if [ "$DOSYA_SAYISI" -gt 0 ]; then
    find "$KAYNAK_DIZIN" -type f -name "*.doc" -printf "%P\0" | tar -czf "$ARSIV" --null -C "$KAYNAK_DIZIN" -T -
    echo "Arşiv oluşturuldu: $(basename "$ARSIV")"
else
    echo "Arşivlenecek .doc dosyası bulunamadı, arşiv oluşturulmadı."
    ARSIV=""
fi

# ------------------------------------------------------------------------------
# 8. İZİN AYARI
# ------------------------------------------------------------------------------
baslik_yaz "8. İZİN AYARI"

if [ -n "$ARSIV" ] && [ -f "$ARSIV" ]; then
    chmod 600 "$ARSIV"
    echo "İzinler ayarlandı (600)"
else
    echo "Ayarlanacak arşiv dosyası mevcut değil."
fi

# ------------------------------------------------------------------------------
# BİTİŞ
# ------------------------------------------------------------------------------
baslik_yaz "BİTİŞ"
echo "İşlem tamamlandı."
