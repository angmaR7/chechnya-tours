from django.contrib import admin
from .models import User


@admin.register(User)
class BookingAdmin(admin.ModelAdmin):
    list_display = ( "username", "email", "first_name", "last_name", "phone_number", )
