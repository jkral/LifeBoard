module GoalsHelper
  def status_badge_classes(status)
    case status.to_sym
    when :todo
      'bg-gray-100 text-gray-800'
    when :in_progress
      'bg-blue-100 text-blue-800'
    when :done
      'bg-green-100 text-green-800'
    else
      'bg-gray-100 text-gray-800'
    end
  end
end
