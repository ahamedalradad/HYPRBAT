#!/bin/bash
# إعادة تشغيل Waybar بشكل نظيف
killall waybar 2>/dev/null
killall swaync 2>/dev/null
waybar & swaync
