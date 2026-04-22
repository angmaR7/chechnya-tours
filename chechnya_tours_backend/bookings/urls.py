from django.urls import path
from .views import (
    BookingCreateAPIView,
    MyBookingListAPIView,
    MyBookingDetailAPIView,
    BookingCancelAPIView,
)

urlpatterns = [
    path("", BookingCreateAPIView.as_view(), name="booking-create"),
    path("my/", MyBookingListAPIView.as_view(), name="my-bookings"),
    path("<int:id>/", MyBookingDetailAPIView.as_view(), name="booking-detail"),
    path("<int:id>/cancel/", BookingCancelAPIView.as_view(), name="booking-cancel"),
]