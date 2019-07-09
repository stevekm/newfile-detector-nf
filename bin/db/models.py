import os
from django.db import models

# Database schema models go here

class File(models.Model):
    filename = models.TextField(blank=False)
    path = models.TextField()
    imported = models.DateTimeField(auto_now_add=True)
    updated = models.DateTimeField(auto_now=True)

    def save(self, *args, **kwargs):
        """
        Update the 'path'
        """
        self.path = os.path.realpath(self.filename)
        # call the parent save method
        super().save(*args, **kwargs)
