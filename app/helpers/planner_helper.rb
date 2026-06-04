module PlannerHelper
  DOW    = %w[domingo lunes martes miércoles jueves viernes sábado].freeze
  DOW_KR = %w[일요일 월요일 화요일 수요일 목요일 금요일 토요일].freeze

  def dow_label(date) = "#{DOW[date.wday]} · #{DOW_KR[date.wday]}"

  def month_name(date)
    %w[Enero Febrero Marzo Abril Mayo Junio Julio Agosto
       Septiembre Octubre Noviembre Diciembre][date.month - 1]
  end

  # Cuenta regresiva desde el día visible hasta el objetivo global (Setting).
  def d_minus_label(from_date, target)
    return "" unless target
    d = (target - from_date).to_i
    d.positive? ? "D-#{d}" : (d.zero? ? "D-DAY" : "D+#{-d}")
  end
end
