require 'rails_helper'

RSpec.feature 'Display header menu links', type: :feature do

  context 'when the user is logged in' do

    # TODO: setup before block so user is logged in
    
    specify 'the user is able to see only logged-in header menu links' do
      visit '/'

      within '.navbar' do
        expect(page).to have_link('How To Use This Site')
        expect(page).to have_link('Evidence Based Scheduling By Joel Spolsky')
        expect(page).to have_link('Milestones')
        expect(page).to have_link('Team Estimate History')
        expect(page).to have_link('Collaborators')
        expect(page).to have_text('Welcome')
        expect(page).not_to have_link('Log In')
        expect(page).to have_link('Log Out')
      end

    end
  end

  context 'when the user is logged out' do
    specify 'the user is able to see only logged-out header menu links' do
      visit '/'

      within '.navbar' do
        expect(page).to have_link('How To Use This Site')
        expect(page).to have_link('Evidence Based Scheduling By Joel Spolsky')
        expect(page).not_to have_link('Milestones')
        expect(page).not_to have_link('Team Estimate History')
        expect(page).not_to have_link('Collaborators')
        expect(page).not_to have_text('Welcome')
        expect(page).to have_link('Log In')
        expect(page).not_to have_link('Log Out')
      end
    end
  end
end
