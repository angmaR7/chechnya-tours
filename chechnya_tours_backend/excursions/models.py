from django.db import models


class Excursion(models.Model):
    class Status(models.TextChoices):
        DRAFT = "draft", "Черновик"
        PUBLISHED = "published", "Опубликована"
        CANCELLED = "cancelled", "Отменена"

    place = models.ForeignKey(
        "places.Place",
        on_delete=models.CASCADE,
        related_name="excursions",
        verbose_name="Достопримечательность",
    )
    title = models.CharField(max_length=255, verbose_name="Название экскурсии")
    description = models.TextField(verbose_name="Описание")

    guide_name = models.CharField(max_length=255, blank=True, verbose_name="Имя гида")

    start_datetime = models.DateTimeField(verbose_name="Дата и время начала")
    duration_minutes = models.PositiveIntegerField(verbose_name="Длительность в минутах")

    price = models.DecimalField(max_digits=10, decimal_places=2, verbose_name="Цена")
    max_people = models.PositiveIntegerField(verbose_name="Максимум человек")
    booked_people = models.PositiveIntegerField(default=0, verbose_name="Забронировано мест")

    status = models.CharField(
        max_length=20,
        choices=Status.choices,
        default=Status.DRAFT,
        verbose_name="Статус",
    )
    is_active = models.BooleanField(default=True, verbose_name="Активна")

    created_at = models.DateTimeField(auto_now_add=True, verbose_name="Создано")
    updated_at = models.DateTimeField(auto_now=True, verbose_name="Обновлено")

    class Meta:
        verbose_name = "Экскурсия"
        verbose_name_plural = "Экскурсии"
        ordering = ["start_datetime"]

    def __str__(self):
        return self.title

    @property
    def available_places(self):
        value = self.max_people - self.booked_people
        return max(value, 0)