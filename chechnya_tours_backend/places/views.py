from rest_framework import generics
from rest_framework.permissions import AllowAny

from .models import Place
from .serializers import PlaceSerializer


class PlaceListAPIView(generics.ListAPIView):
    queryset = Place.objects.filter(is_active=True)
    serializer_class = PlaceSerializer
    permission_classes = [AllowAny]


class PlaceDetailAPIView(generics.RetrieveAPIView):
    queryset = Place.objects.filter(is_active=True)
    serializer_class = PlaceSerializer
    permission_classes = [AllowAny]
    lookup_field = "id"