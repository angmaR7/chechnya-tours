from django.urls import path
from .views import ExcursionListAPIView, ExcursionDetailAPIView

urlpatterns = [
    path("", ExcursionListAPIView.as_view(), name="excursion-list"),
    path("<int:id>/", ExcursionDetailAPIView.as_view(), name="excursion-detail"),
]