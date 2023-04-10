require 'rails_helper'
require_relative '../login_module'

RSpec.describe('Event', type: :feature) do
   login

   it "searches by name" do
    event = Event.new(name: "Tailgate", event_type: 3, date: '12/12/2023',
        description: 'cookout where you can meet fellow members.', start_time: "Sat, 01 Jan 2000 06:00:00.000000000 CST -06:00",
        end_time: start_time: "Sat, 01 Jan 2000 06:00:00.000000000 CST -08:00").save
        events = Event.search("tail",'')
        expect(events[0].name).to(eq("Tailgate"))
   end

   it "searches by category" do
    event = Event.new(name: "Tailgate", event_type: 3, date: '12/12/2023',
        description: 'cookout where you can meet fellow members.', start_time: "Sat, 01 Jan 2000 06:00:00.000000000 CST -06:00", end_time: start_time: "Sat, 01 Jan 2000 06:00:00.000000000 CST -08:00").save
    events = Event.search('','Social')
    expect(events[0].event_type).to(eq(3))
   end

   it "returns all events if no event has searched name (w/o category)" do
    event = Event.new(name: "Tailgate", event_type: 3, date: '12/12/2023',
        description: 'cookout where you can meet fellow members.').save
    event2 = Event.new(name: "cookout", event_type: 2, date: '08/12/2023',
        description: 'cookout where you can meet fellow members.').save
    all_events = Event.all
    events = Event.search("xyz", '')

    expect(events).to(eq(all_events))
   end

   it "returns all events if no event has searched name (w/ category)" do
    event = Event.new(name: "Tailgate", event_type: 3, date: '12/12/2023',
        description: 'cookout where you can meet fellow members.').save
    event2 = Event.new(name: "cookout", event_type: 2, date: '08/12/2023',
        description: 'cookout where you can meet fellow members.').save
    all_events = Event.all
    events = Event.search("xyz", 'Social')

    expect(events).to(eq(all_events))
   end
end