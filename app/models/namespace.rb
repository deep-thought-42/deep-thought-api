class Namespace
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :namespace, optional: true
  has_many :permissions, class_name: "NamespacePermission"

  field :name, type: String

  validates :name, presence: true, uniqueness: { scope: [:namespace_id] }

  def namespaces
    nps = [self]
    nps += namespace.namespaces if namespace.present?
    nps.compact
  end

  def permissions_for(user)
    permissions = NamespacePermission.where(user: user, :namespace_id.in => namespaces.pluck(:_id))    
    return permissions.pluck(:permissions).flatten.uniq if permissions.present?
    []
  end
end
