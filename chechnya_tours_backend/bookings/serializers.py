from django.db import transaction
from rest_framework import serializers

from excursions.models import Excursion
from .models import Booking


class BookingSerializer(serializers.ModelSerializer):
    excursion_title = serializers.CharField(source="excursion.title", read_only=True)
    place_name = serializers.CharField(source="excursion.place.name", read_only=True)

    excursion_start_datetime = serializers.DateTimeField(source="excursion.start_datetime", read_only=True)
    guide_name = serializers.CharField(source="excursion.guide_name", read_only=True)
    price_per_person = serializers.DecimalField(source="excursion.price", max_digits=10, decimal_places=2,
                                                read_only=True)

    class Meta:
        model = Booking
        fields = [
            "id",
            "user",
            "excursion",
            "excursion_title",
            "place_name",
            "full_name",
            "phone_number",
            "email",
            "people_count",
            "total_price",
            "comment",
            "status",
            "created_at",
            "updated_at",
            "excursion_start_datetime",
            "guide_name",
            "price_per_person",
        ]
        read_only_fields = [
            "id",
            "user",
            "total_price",
            "status",
            "created_at",
            "updated_at",
            "excursion_title",
            "place_name",
            "excursion_start_datetime",
            "guide_name",
            "price_per_person",
        ]

    def validate_people_count(self, value):
        if value <= 0:
            raise serializers.ValidationError("Количество человек должно быть больше 0.")
        return value

    def validate(self, attrs):
        excursion = attrs["excursion"]
        people_count = attrs["people_count"]

        if not excursion.is_active:
            raise serializers.ValidationError("Экскурсия недоступна для бронирования.")

        if excursion.status != Excursion.Status.PUBLISHED:
            raise serializers.ValidationError("Экскурсия не опубликована.")

        available_places = excursion.max_people - excursion.booked_people
        if people_count > available_places:
            raise serializers.ValidationError(
                f"Недостаточно мест. Доступно мест: {available_places}."
            )

        return attrs

    def create(self, validated_data):
        request = self.context.get("request")
        excursion_id = validated_data["excursion"].id
        people_count = validated_data["people_count"]

        with transaction.atomic():
            excursion = (
                Excursion.objects
                .select_for_update()
                .get(id=excursion_id)
            )

            if not excursion.is_active:
                raise serializers.ValidationError("Экскурсия недоступна для бронирования.")

            if excursion.status != Excursion.Status.PUBLISHED:
                raise serializers.ValidationError("Экскурсия не опубликована.")

            available_places = excursion.max_people - excursion.booked_people
            if people_count > available_places:
                raise serializers.ValidationError(
                    f"Недостаточно мест. Доступно мест: {available_places}."
                )

            booking = Booking.objects.create(
                user=request.user,
                excursion=excursion,
                full_name=validated_data["full_name"],
                phone_number=validated_data["phone_number"],
                email=validated_data.get("email", ""),
                people_count=people_count,
                total_price=excursion.price * people_count,
                comment=validated_data.get("comment", ""),
            )

            excursion.booked_people += people_count
            excursion.save(update_fields=["booked_people"])

        return booking