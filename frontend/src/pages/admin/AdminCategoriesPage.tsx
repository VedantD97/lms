import { useState } from "react";
import { Button } from "@/components/ui/Button";
import { Input, Label, Textarea } from "@/components/ui/Field";
import { EmptyState } from "@/components/feedback/EmptyState";
import { LoadingSpinner } from "@/components/feedback/LoadingSpinner";
import { PageHeader } from "@/components/shared/PageHeader";
import {
  useAdminCategories,
  useCreateAdminCategory,
  useDeleteAdminCategory,
  useUpdateAdminCategory,
} from "@/features/admin/courses/hooks/useAdminCourses";

export function AdminCategoriesPage() {
  const { data: categories, isLoading } = useAdminCategories();
  const createCategory = useCreateAdminCategory();
  const updateCategory = useUpdateAdminCategory();
  const removeCategory = useDeleteAdminCategory();
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");

  return (
    <div>
      <PageHeader title="Categories" description="Organize courses into categories." />

      <form
        onSubmit={(event) => {
          event.preventDefault();
          createCategory.mutate(
            { name, description },
            {
              onSuccess: () => {
                setName("");
                setDescription("");
              },
            },
          );
        }}
        className="mb-8 max-w-xl space-y-4 rounded-xl border border-slate-200 bg-white p-6"
      >
        <h2 className="text-lg font-semibold text-slate-900">New category</h2>
        <div>
          <Label htmlFor="name">Name</Label>
          <Input id="name" value={name} onChange={(e) => setName(e.target.value)} required />
        </div>
        <div>
          <Label htmlFor="description">Description</Label>
          <Textarea id="description" value={description} onChange={(e) => setDescription(e.target.value)} />
        </div>
        <Button type="submit" disabled={createCategory.isPending}>
          Create category
        </Button>
      </form>

      {isLoading ? (
        <LoadingSpinner label="Loading categories..." />
      ) : !categories?.length ? (
        <EmptyState title="No categories yet" description="Create your first category above." />
      ) : (
        <div className="space-y-3">
          {categories.map((category) => (
            <CategoryRow
              key={category.uuid}
              category={category}
              onSave={(payload) => updateCategory.mutate({ uuid: category.uuid, payload })}
              onDelete={() => removeCategory.mutate(category.uuid)}
            />
          ))}
        </div>
      )}
    </div>
  );
}

function CategoryRow({
  category,
  onSave,
  onDelete,
}: {
  category: { uuid: string; name: string; description?: string };
  onSave: (payload: { name: string; description?: string }) => void;
  onDelete: () => void;
}) {
  const [name, setName] = useState(category.name);
  const [description, setDescription] = useState(category.description ?? "");

  return (
    <div className="flex flex-wrap items-end gap-3 rounded-xl border border-slate-200 bg-white p-4">
      <div className="min-w-[200px] flex-1">
        <Label>Name</Label>
        <Input value={name} onChange={(e) => setName(e.target.value)} />
      </div>
      <div className="min-w-[240px] flex-[2]">
        <Label>Description</Label>
        <Input value={description} onChange={(e) => setDescription(e.target.value)} />
      </div>
      <Button variant="secondary" onClick={() => onSave({ name, description })}>
        Save
      </Button>
      <Button variant="danger" onClick={onDelete}>
        Delete
      </Button>
    </div>
  );
}
