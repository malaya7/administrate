module Administrate
  module ApplicationHelper
    PLURAL_MANY_COUNT = 2.1
    SINGULAR_COUNT = 1

    def application_title
      if Rails::VERSION::MAJOR <= 5
        Rails.application.class.parent_name.titlecase
      else
        Rails.application.class.module_parent_name.titlecase
      end
    end

    def render_field(field, locals = {})
      locals[:field] = field
      render locals: locals, partial: field.to_partial_path
    end

    def requireness(field)
      field.required? ? "required" : "optional"
    end

    def dashboard_from_resource(resource_name)
      "#{resource_name.to_s.singularize}_dashboard".classify.constantize
    end

    def model_from_resource(resource_name)
      dashboard = dashboard_from_resource(resource_name)
      dashboard.try(:model) || resource_name.to_sym
    end

    def display_resource_name(resource_name, opts = {})
      dashboard_from_resource(resource_name).resource_name(
        count: opts[:singular] ? SINGULAR_COUNT : PLURAL_MANY_COUNT,
        default: default_resource_name(resource_name, opts),
      )
    end

    def sort_order(order)
      case order
      when "asc" then "ascending"
      when "desc" then "descending"
      else "none"
      end
    end

    def resource_index_route(resource_name)
      url_for(
        action: "index",
        controller: "/#{namespace}/#{resource_name}",
      )
    end

    def sanitized_order_params(page, current_field_name)
      collection_names = page.item_includes + [current_field_name]
      association_params = collection_names.map do |assoc_name|
        { assoc_name => %i[order direction page per_page] }
      end
      params.permit(
        :search,
        :id,
        :_page,
        :per_page,
        association_params,
        :extra_columns,
      )
    end

    def clear_search_params
      params.except(:search, :_page).permit(:extra_columns,
        :per_page, resource_name => %i[order direction]
      )
    end

    private

    def default_resource_name(name, opts = {})
      resource_name = (opts[:singular] ? name.to_s : name.to_s.pluralize)
      resource_name.gsub("/", "_").titleize
    end
  end
end
