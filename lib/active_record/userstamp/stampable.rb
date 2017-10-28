# Extends the stamping functionality of ActiveRecord by automatically recording the model
# responsible for creating, updating, and deleting the current object. See the +Stamper+ and
# +ControllerAdditions+ modules for further documentation on how the entire process works.
module ActiveRecord::Userstamp::Stampable
  extend ActiveSupport::Concern

  module BuilderExtension
    def self.build(model, reflection)
      model.send(:add_userstamp_association_callbacks, reflection)
    end

    def self.valid_options
      [ :touch_updater ]
    end
  end

  included do
    ActiveRecord::Associations::Builder::Association.extensions << BuilderExtension

    # Should ActiveRecord record userstamps? Defaults to false.
    # todo: could probably remove
    class_attribute  :record_userstamp
    self.record_userstamp = false

    class_attribute  :stamper_class_name

    before_validation :set_updater_attribute, if: :record_userstamp
    before_validation :set_creator_attribute, on: :create, if: :record_userstamp
    before_save :set_updater_attribute, if: :record_userstamp
    before_save :set_creator_attribute, on: :create, if: :record_userstamp
    before_destroy :set_deleter_attribute, if: :record_userstamp
  end

  module ClassMethods
    def columns(*)
      columns = super
      return columns if defined?(@stamper_initialized) && @stamper_initialized

      add_userstamp_associations({})
      columns
    end

    # This method customizes how the gem functions. For example:
    #
    #   class Post < ActiveRecord::Base
    #     stampable stamper_class_name: Person.name,
    #               with_deleted:       true
    #   end
    #
    # The method will set up all the associations. Extra arguments (like +:with_deleted+) will be
    # propagated to the associations.
    #
    # By default, the deleter association is not defined unless the :deleter_attribute is set in
    # the gem configuration.
    def stampable(options = {})
      if options[:polymorphic]
        # model_stamper
        self.stamper_class_name = 'ActiveRecord::Userstamp::PolyStamper'
      else
        self.stamper_class_name = options.delete(:stamper_class_name) if options.key?(:stamper_class_name)
      end

      self.record_userstamp = true
      add_userstamp_associations(options)
    end

    # Temporarily allows you to turn stamping off. For example:
    #
    #   Post.without_stamps do
    #     post = Post.find(params[:id])
    #     post.update_attributes(params[:post])
    #     post.save
    #   end
    def without_stamps
      original_value = self.record_userstamp
      self.record_userstamp = false
      yield
    ensure
      self.record_userstamp = original_value
    end

    def stamper_class #:nodoc:
      stamper_class_name.to_s.camelize.constantize rescue nil
    end

    private

    # Defines the associations for Userstamp.
    def add_userstamp_associations(options)
      return unless self.record_userstamp

      @stamper_initialized = true
      ActiveRecord::Userstamp::Utilities.remove_association(self, :creator)
      ActiveRecord::Userstamp::Utilities.remove_association(self, :updater)
      ActiveRecord::Userstamp::Utilities.remove_association(self, :deleter)

      associations = ActiveRecord::Userstamp::Utilities.available_association_columns(self)
      return if associations.nil?

      config = ActiveRecord::Userstamp.config

      if options[:polymorphic]
        relation_options = options.reverse_merge(polymorphic: true)

        belongs_to :creator, relation_options if
          associations.first
        belongs_to :updater, relation_options if
          associations.second
        belongs_to :deleter, relation_options if
          associations.third

      else
        klass = stamper_class.try(:name)
        relation_options = options.reverse_merge(class_name: klass)

        belongs_to :creator, relation_options.reverse_merge(foreign_key: config.creator_attribute) if
          associations.first
        belongs_to :updater, relation_options.reverse_merge(foreign_key: config.updater_attribute) if
          associations.second
        belongs_to :deleter, relation_options.reverse_merge(foreign_key: config.deleter_attribute) if
          associations.third
      end
    end

    def add_userstamp_association_callbacks(reflection)
      if reflection.options[:touch_updater]

        callback = lambda { touch_record(reflection) }

        self.after_save callback, if: :changed?
        self.after_destroy callback
      end
    end
  end

  private

  def has_stamper?
    !self.class.stamper_class.nil? && !self.class.stamper_class.stamper.nil?
  end

  def set_creator_attribute
    return unless has_stamper?

    creator_association = self.class.reflect_on_association(:creator)
    return unless creator_association
    return if creator.present?

    ActiveRecord::Userstamp::Utilities.assign_stamper(self, creator_association)
  end

  def set_updater_attribute
    return unless has_stamper?

    updater_association = self.class.reflect_on_association(:updater)
    return unless updater_association
    return unless changed?

    ActiveRecord::Userstamp::Utilities.assign_stamper(self, updater_association)
  end

  def set_deleter_attribute
    return unless has_stamper?

    deleter_association = self.class.reflect_on_association(:deleter)
    return unless deleter_association

    ActiveRecord::Userstamp::Utilities.assign_stamper(self, deleter_association)
    save
  end

  def touch_record(reflection)
    old_foreign_id = changed_attributes[reflection.foreign_key]

    if old_foreign_id
      if reflection.polymorphic?
        klass = public_send("#{reflection.foreign_type}_was").constantize
      else
        klass = reflection.klass
      end
      old_record = klass.find_by(klass.primary_key => old_foreign_id)

      if old_record
        old_record.update(updater: self.class.stamper_class.stamper)
      end
    end

    record = send(reflection.name)
    if record && record.persisted?
      record.update(updater: self.class.stamper_class.stamper)
    end
  end
end

