# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Event, type: :model) do
  context 'validation tests' do
    it 'ensures event name' do
      event = Event.new(event_type: 3, date: '12/12/2099',
                        description: 'cookout where you can meet fellow members.', start_time: Time.zone.now,
                        end_time: Time.zone.now + 2.hours).save
      expect(event).to(eq(false))
    end

    it 'ensures event date' do
      event = Event.new(name: 'Tailgate', event_type: 3, description: 'cookout where you can meet fellow members.',
                        start_time: Time.zone.now, end_time: Time.zone.now + 2.hours).save
      expect(event).to(eq(false))
    end

    # #ensures the date for the event is after the day the event was created.
    # #ensures the date is of the format DD/MM/YYYY (or change it so it has to be MM/DD/YYYY)

    it 'ensures event description' do
      event = Event.new(name: 'Tailgate', event_type: 3, date: '12/12/2099', start_time: Time.zone.now,
                        end_time: Time.zone.now + 2.hours).save
      expect(event).to(eq(false))
    end

    it 'ensures event type' do
      event = Event.new(name: 'Tailgate', date: '12/12/2099',
                        description: 'cookout where you can meet fellow members.', start_time: Time.zone.now,
                        end_time: Time.zone.now + 2.hours).save
      expect(event).to(eq(false))
    end

    it 'ensures start time is before end time' do
      event = Event.new(name: 'Tailgate', event_type: 3, date: '12/12/2099',
                        description: 'cookout where you can meet fellow members.', start_time: Time.zone.now + 2.hours,
                        end_time: Time.zone.now).save
      expect(event).to(eq(false))
    end

    it 'ensures all attributes are present' do
      event = Event.new(name: 'Tailgate', event_type: 3, date: '12/12/2099',
                        description: 'cookout where you can meet fellow members.', start_time: Time.zone.now,
                        end_time: Time.zone.now + 2.hours).save
    end
  end
end
