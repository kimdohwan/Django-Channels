from channels.auth import AuthMiddlewareStack
from channels.routing import ProtocolTypeRouter, URLRouter
from django.urls import path, re_path

import alarms.routing
import chat.routing
from alarms.consumers import UserTestConsumer
from chat import consumers
from chat.consumers import ChatConsumer

application = ProtocolTypeRouter({
    # chat app
    'websocket': AuthMiddlewareStack(
        URLRouter([
            # chat.routing.websocket_urlpatterns,
            # alarms.routing.websocket_urlpatterns,
            path('ws/chat/<room_name>/', ChatConsumer),
            re_path(r'ws/test/(?P<username>.*)/', UserTestConsumer),
        ])
    )

    # # alarms app
    # 'websocket': URLRouter(
    #     alarms.routing.websocket_urlpatterns
    # )
})
