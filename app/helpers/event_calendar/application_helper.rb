module EventCalendar::ApplicationHelper
  def link_wrapper(path, wrapper_options={}, link_options={})
    tag       = wrapper_options.delete(:tag) || :p
    link_text = link_options.delete(:link_text) || path
    highlight = wrapper_options.delete(:highlight)
  
    unless path.blank?
      if current_page?(path) && (highlight.nil? || highlight)
        wrapper_options.merge!({
          :class => (wrapper_options[:class] || '') + " nav_highlight"
        })
      end
    end
  
    unless wrapper_options.delete(:no_wrapper)
      return content_tag(tag, wrapper_options) do
        link_to(link_text, path, link_options)
      end
    else
      return link_to(link_text, path, link_options)
    end
  end
  
  def link_to_events(wrapper_options={}, link_options={})
    link_wrapper(events_path, wrapper_options, link_options.reverse_merge!({
      :link_text => 'Event Calendar'
    }))
  end

  def link_to_new_event(wrapper_options={})
    return unless has_authorization?(:create, Event.new)
    link_wrapper(new_event_path, wrapper_options, {
      :link_text => "Create New Event"
    })
  end

  def link_to_deleted_events(wrapper_options={})
    link_wrapper(event_revisions_path, wrapper_options, {
      :link_text => "Restore Deleted Events (#{EventRevision.deleted.count})"
    })
  end

  def link_to_add_event_attendees(event, wrapper_options={})
    return unless has_authorization?(:add_attendees, event)
    link_wrapper(new_event_attendee_path(event), wrapper_options, {
      :link_text => "Add <em>#{h(event.name)}</em> Attendees".html_safe
    })
  end

  def link_to_edit_event(event, wrapper_options={})
    return unless has_authorization?(:update, event)
    link_wrapper(edit_event_path(event), wrapper_options, {
      :link_text => "Edit <em>#{h(event.name)}</em>".html_safe
    })
  end

  def link_to_delete_event(event, wrapper_options={})
    return unless has_authorization?(:delete, event)
    link_wrapper(event_path(event), {
      :highlight => false
    }.merge!(wrapper_options), {
      :link_text => "Delete <em>#{event.name}</em>".html_safe,
      :confirm => 'Are you sure you want to permanently delete this event?',
      :method => "delete"
    })
  end

  def form_for_browse_event_revisions(event)
    render :partial => 'events/browse_event_revisions', :locals => {
      :event => event
    }
  end

  def render_event_navigation(event=nil)
    render :partial => 'event-calendar-shared/navigation', :locals => {
      :event => event
    }
  end

  def render_event_main_menu
    render :partial => 'event-calendar-shared/main_menu'
  end

  def render_flash
    render :partial => 'event-calendar-shared/flash', :object => flash
  end
  
  def event_calendar_asset_prefix
    'event_calendar/'
  end
  
  def event_calendar_javascript_includes
    list = [
      "#{event_calendar_asset_prefix}jquery.tablesorter.min.js",
      "#{event_calendar_asset_prefix}jquery-ui-1.7.2.custom.min.js",
      "#{event_calendar_asset_prefix}jquery.string.1.0-min.js",
      "#{event_calendar_asset_prefix}jquery.clonePosition.js",
      "#{event_calendar_asset_prefix}lowpro.jquery.js",
      "#{event_calendar_asset_prefix}fullcalendar.js",
      "#{event_calendar_asset_prefix}jquery.qtip-1.0.0-rc3.js",
      "#{event_calendar_asset_prefix}rails",
      "#{event_calendar_asset_prefix}event_calendar_behaviors.js",
      "#{event_calendar_asset_prefix}event_calendar.js"
    ]
    unless Rails.env == 'production'
      list.unshift("#{event_calendar_asset_prefix}jquery")
    else
      list.unshift("http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js")
    end
  end
end
