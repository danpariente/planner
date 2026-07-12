module PlannerHelper
  DOW_KR = %w[일요일 월요일 화요일 수요일 목요일 금요일 토요일].freeze

  def dow_label(date) = "#{t("date.day_names")[date.wday]} · #{DOW_KR[date.wday]}"

  def month_name(date) = t("date.month_names")[date.month]

  # Cuenta regresiva desde el día visible hasta el objetivo global (Setting).
  def d_minus_label(from_date, target)
    return "" unless target
    d = (target - from_date).to_i
    d.positive? ? "D-#{d}" : (d.zero? ? "D-DAY" : "D+#{-d}")
  end

  # Enlace al otro idioma, conservando la página actual.
  def locale_toggle(css_class)
    other = I18n.locale == :es ? :en : :es
    link_to other.to_s.upcase, url_for(request.query_parameters.symbolize_keys.merge(locale: other)),
            class: css_class, title: (other == :en ? "English" : "Español")
  end
end
