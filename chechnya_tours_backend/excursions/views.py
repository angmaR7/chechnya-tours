from rest_framework import generics
from rest_framework.permissions import AllowAny

from .models import Excursion
from .serializers import ExcursionListSerializer, ExcursionDetailSerializer


class ExcursionListAPIView(generics.ListAPIView):
    permission_classes = [AllowAny]

    def get_queryset(self):
        queryset = (
            Excursion.objects
            .filter(is_active=True, status=Excursion.Status.PUBLISHED)
            .select_related("place")
        )

        place_id = self.request.query_params.get("place")
        if place_id:
            queryset = queryset.filter(place_id=place_id)

        return queryset

    def get_serializer_class(self):
        return ExcursionListSerializer


class ExcursionDetailAPIView(generics.RetrieveAPIView):
    serializer_class = ExcursionDetailSerializer
    permission_classes = [AllowAny]
    lookup_field = "id"

    def get_queryset(self):
        return (
            Excursion.objects
            .filter(is_active=True, status=Excursion.Status.PUBLISHED)
            .select_related("place")
        )