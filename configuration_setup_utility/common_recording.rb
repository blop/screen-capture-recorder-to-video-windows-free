require 'java'
require 'add_vendored_gems_to_load_path'

splash = java.awt.SplashScreen.splash_screen
splash.close if splash # close it early'ish...not sure how this looks on slower computers...

require 'jruby-swing-helpers/lib/simple_gui_creator'

include SimpleGuiCreator # ::DropDownSelector, etc.
require 'ffmpeg_helpers'

VirtualAudioDeviceName = 'virtual-audio-capturer'
ScreenCapturerDeviceName = 'screen-capture-recorder' 

def choose_devices
  videos = ['none'] + FfmpegHelpers.enumerate_directshow_devices[:video].sort_by{|name| name == ScreenCapturerDeviceName ? 0 : 1}  # put none in front :)
  original_video_device=video_device = DropDownSelector.new(nil, videos, "Select video device to capture, or \"none\" to record audio only").go_selected_value
  if video_device == 'none'
    video_device = nil
  else
    # stay same
  end

  audios = ['none'] + FfmpegHelpers.enumerate_directshow_devices[:audio].sort_by{|name| name == VirtualAudioDeviceName ? 0 : 1}
  audio_device = DropDownSelector.new(nil, audios, "Select audio device to capture, or none").go_selected_value
  if audio_device == 'none'
    audio_device = nil 
  else
    # stay same
  end
  
  unless audio_device || video_device
   SimpleGuiCreator.show_blocking_message_dialog('must select at least one')
   exit 1
  end
  
  if original_video_device == ScreenCapturerDeviceName
    SimpleGuiCreator.show_blocking_message_dialog "you can setup parameters [like frames per second, size] for the screen capture recorder\n in its separate setup configuration utility"
  end

  [audio_device, video_device] 
end

def combine_devices_for_ffmpeg_input audio_device, video_device # NB not for ffplay input!! won't work with ffplay but it should shouldn't it?
 if audio_device
   audio_device="-f dshow -i audio=\"#{FfmpegHelpers.escape_for_input audio_device}\""
 end
 if video_device
   video_device="-f dshow -i video=\"#{FfmpegHelpers.escape_for_input video_device}\""
 end
 "#{video_device} #{audio_device}"
end