require 'processors/lib/find_call'

#This processor specifically looks for calls like
# User.active.human.find(:all, :conditions => ...)
class FindModelCall < FindCall

  #Passes +targets+ to FindCall
  def initialize targets
    super(targets, /^(find.*|first|last|all|count|sum|average|minumum|maximum|count_by_sql)$/)
  end 

  #Matches entire method chain as a target. This differs from
  #FindCall#get_target, which only matches the first expression in the chain.
  def get_target exp
    if sexp? exp
      case exp.node_type
      when :ivar, :lvar, :const
        exp[1]
      when :true, :false
        exp[0]
      when :lit
        exp[1]
      when :colon2
        class_name exp
      when :call
        t = get_target(exp[1])
        if t and match(@find_targets, t)
          t
        else
          process exp
        end
      else
        process exp
      end
    else
      exp
    end
  end
end
