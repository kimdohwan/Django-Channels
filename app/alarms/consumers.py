import json

from asgiref.sync import async_to_sync
from channels.generic.websocket import WebsocketConsumer
from channels.layers import get_channel_layer
from django.db.models.signals import post_save
from django.dispatch import receiver

from .models import Alarm


@receiver(post_save, sender=Alarm)
def announce_likes(sender, instance, created, **kwargs):
    if created:
        channel_layer = get_channel_layer()
        async_to_sync(channel_layer.group_send)(
            'shares',
            {
                'type': 'share_message',
                'message': instance.message,
            }
        )


class UserTestConsumer(WebsocketConsumer):
    def connect(self):
        self.groupname = 'shares'
        self.accept()

        async_to_sync(self.channel_layer.group_add)(
            self.groupname,
            self.channel_name,
        )

    def disconnect(self, close_code):
        async_to_sync(self.channel_layer.group_discard)(
            self.groupname,
            self.channel_name,
        )

    def share_message(self, event):
        message = event['message']

        # send message to websocket
        self.send(text_data=json.dumps({
            'message': message
        }))
