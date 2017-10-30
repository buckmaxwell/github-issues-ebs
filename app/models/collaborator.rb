class Collaborator < ApplicationRecord
  def random_velocity
    a = JSON.parse history
    a.sample.to_f
  end

  def get_history_chart_data
    result = [%w[Estimate Actual Perfect]]
    hist = JSON.parse tuple_history
    hist.each do |est, act|
      result << [est, act, est]
    end
    result
  end
end
