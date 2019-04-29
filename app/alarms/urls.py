from django.urls import path

from . import views

urlpatterns = [
    path('Alarm/', views.Alarm.as_view()),
    path('ShareMe/', views.ShareMe.as_view()),
]