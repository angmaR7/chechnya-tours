from django.contrib import admin
from .models import Excursion


@admin.register(Excursion)
class ExcursionAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "title",
        "place",
        "start_datetime",
        "price",
        "max_people",
        "booked_people",
        "status",
        "is_active",
    )
    list_filter = ("status", "is_active", "place")
    search_fields = ("title", "description", "guide_name", "place__name")