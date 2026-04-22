from rest_framework import serializers

from places.models import Place
from .models import Excursion


class PlaceInExcursionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Place
        fields = [
            "id",
            "name",
            "slug",
            "short_description",
            "description",
            "city",
            "district",
            "address",
            "latitude",
            "longitude",
            "image_url",
        ]


class ExcursionListSerializer(serializers.ModelSerializer):
    place_name = serializers.CharField(source='place.name', read_only=True)
    place_image_url = serializers.CharField(source='place.image_url', read_only=True)
    available_places = serializers.IntegerField(read_only=True)

    class Meta:
        model = Excursion
        fields = [
            "id",
            "place",
            "place_name",
            "place_image_url",
            "title",
            "description",
            "guide_name",
            "start_datetime",
            "duration_minutes",
            "price",
            "max_people",
            "booked_people",
            "available_places",
            "status",
            "is_active",
        ]


class ExcursionDetailSerializer(serializers.ModelSerializer):
    place = PlaceInExcursionSerializer(read_only=True)
    available_places = serializers.IntegerField(read_only=True)
    is_bookable = serializers.SerializerMethodField()

    class Meta:
        model = Excursion
        fields = [
            "id",
            "place",
            "title",
            "description",
            "guide_name",
            "start_datetime",
            "duration_minutes",
            "price",
            "max_people",
            "booked_people",
            "available_places",
            "is_bookable",
            "status",
            "is_active",
            "created_at",
            "updated_at",
        ]

    def get_is_bookable(self, obj):
        return (
            obj.is_active
            and obj.status == Excursion.Status.PUBLISHED
            and obj.available_places > 0
        )