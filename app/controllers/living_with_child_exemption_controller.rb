class LivingWithChildExemptionController < QuestionController
  include WrExemptionsConcern

  def self.show?(screener)
    super && screener.has_child_yes? && (screener.receives_snap_yes? || screener.receives_snap_applied_waiting?)
  end
end
