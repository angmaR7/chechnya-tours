from django.db import transaction
from rest_framework import generics, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from excursions.models import Excursion
from .models import Booking
from .serializers import BookingSerializer


class BookingCreateAPIView(generics.CreateAPIView):
    queryset = Booking.objects.select_related("excursion", "user")
    serializer_class = BookingSerializer
    permission_classes = [IsAuthenticated]


class MyBookingListAPIView(generics.ListAPIView):
    serializer_class = BookingSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return (
            Booking.objects
            .filter(user=self.request.user)
            .select_related("excursion", "excursion__place", "user")
            .order_by("-created_at")
        )


class MyBookingDetailAPIView(generics.RetrieveAPIView):
    serializer_class = BookingSerializer
    permission_classes = [IsAuthenticated]
    lookup_field = "id"

    def get_queryset(self):
        return (
            Booking.objects
            .filter(user=self.request.user)
            .select_related("excursion", "excursion__place", "user")
        )


class BookingCancelAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, id):
        try:
            with transaction.atomic():
                booking = (
                    Booking.objects
                    .select_related("excursion")
                    .select_for_update()
                    .get(id=id, user=request.user)
                )

                if booking.status == Booking.Status.CANCELLED:
                    return Response(
                        {"detail": "Бронирование уже отменено."},
                        status=status.HTTP_400_BAD_REQUEST,
                    )

                if booking.status == Booking.Status.COMPLETED:
                    return Response(
                        {"detail": "Завершенное бронирование отменить нельзя."},
                        status=status.HTTP_400_BAD_REQUEST,
                    )

                excursion = (
                    Excursion.objects
                    .select_for_update()
                    .get(id=booking.excursion_id)
                )

                excursion.booked_people = max(
                    excursion.booked_people - booking.people_count,
                    0
                )
                excursion.save(update_fields=["booked_people"])

                booking.status = Booking.Status.CANCELLED
                booking.save(update_fields=["status", "updated_at"])

                serializer = BookingSerializer(booking)
                return Response(serializer.data, status=status.HTTP_200_OK)

        except Booking.DoesNotExist:
            return Response(
                {"detail": "Бронирование не найдено."},
                status=status.HTTP_404_NOT_FOUND,
            )