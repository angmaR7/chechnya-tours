from django.db import models


class Place(models.Model):
    name = models.CharField(max_length=255, verbose_name="Название")
    slug = models.SlugField(max_length=255, unique=True, verbose_name="Слаг")
    short_description = models.CharField(max_length=500, blank=True, verbose_name="Краткое описание")
    description = models.TextField(verbose_name="Полное описание")

    city = models.CharField(max_length=100, verbose_name="Город / населенный пункт")
    district = models.CharField(max_length=100, blank=True, verbose_name="Район")
    address = models.CharField(max_length=255, blank=True, verbose_name="Адрес")

    latitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True, verbose_name="Широта")
    longitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True, verbose_name="Долгота")

    image_url = models.URLField(blank=True, verbose_name="Ссылка на изображение")

    is_active = models.BooleanField(default=True, verbose_name="Активно")
    created_at = models.DateTimeField(auto_now_add=True, verbose_name="Создано")
    updated_at = models.DateTimeField(auto_now=True, verbose_name="Обновлено")

    class Meta:
        verbose_name = "Достопримечательность"
        verbose_name_plural = "Достопримечательности"
        ordering = ["name"]

    def __str__(self):
        return self.name