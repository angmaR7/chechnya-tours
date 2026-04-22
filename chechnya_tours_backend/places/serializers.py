from rest_framework import serializers
from .models import Place


class PlaceSerializer(serializers.ModelSerializer):
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
            "is_active",
            "created_at",
            "updated_at",
        ]