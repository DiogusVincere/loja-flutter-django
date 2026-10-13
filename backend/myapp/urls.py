from django.urls import path, include
from rest_framework import routers
from .views import ProductViewSet, OrderViewSet, CustomTokenObtainPairView, RegisterView
from rest_framework_simplejwt.views import TokenObtainPairView
from .serializers import EmailTokenObtainPairSerializer
# se tiver AddressViewSet ou UserViewSet, adicione também

class EmailTokenObtainPairView(TokenObtainPairView):
    serializer_class = EmailTokenObtainPairSerializer

router = routers.DefaultRouter()
router.register(r'products', ProductViewSet, basename='product')
router.register(r'orders', OrderViewSet, basename='order')
# se quiser user endpoints publique com cuidado:
# router.register(r'users', UserViewSet, basename='user')

urlpatterns = [
    path('', include(router.urls)),
    path('auth/login/', CustomTokenObtainPairView.as_view(), name='auth_login'),
    path('auth/register/', RegisterView.as_view(), name='auth_register'),
]
