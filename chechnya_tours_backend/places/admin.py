from django.contrib import admin
from .models import Place


@admin.register(Place)
class PlaceAdmin(admin.ModelAdmin):
    list_display = ("id", "name", "city", "district", "is_active", "created_at")
    list_filter = ("is_active", "city", "district")
    search_fields = ("name", "city", "district", "description")
    prepopulated_fields = {"slug": ("name",)}