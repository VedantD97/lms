import { useState } from "react";
import { Button } from "@/components/ui/Button";
import { Input, Label, Textarea } from "@/components/ui/Field";
import { LoadingSpinner } from "@/components/feedback/LoadingSpinner";
import { PageHeader } from "@/components/shared/PageHeader";
import {
  useAdminAnnouncements,
  useCreateAdminAnnouncement,
  useDeleteAdminAnnouncement,
  usePublishAdminAnnouncement,
} from "@/features/admin/announcements/hooks/useAdminAnnouncements";

export function AdminAnnouncementsPage() {
  const { data, isLoading } = useAdminAnnouncements();
  const createAnnouncement = useCreateAdminAnnouncement();
  const publish = usePublishAdminAnnouncement();
  const remove = useDeleteAdminAnnouncement();
  const [title, setTitle] = useState("");
  const [body, setBody] = useState("");

  return (
    <div>
      <PageHeader title="Announcements" description="Publish global announcements to all students." />

      <form
        className="mb-8 max-w-2xl space-y-4 rounded-xl border border-slate-200 bg-white p-6"
        onSubmit={async (event) => {
          event.preventDefault();
          await createAnnouncement.mutateAsync({ title, body });
          setTitle("");
          setBody("");
        }}
      >
        <div>
          <Label htmlFor="title">Title</Label>
          <Input id="title" value={title} onChange={(e) => setTitle(e.target.value)} required />
        </div>
        <div>
          <Label htmlFor="body">Body</Label>
          <Textarea id="body" rows={4} value={body} onChange={(e) => setBody(e.target.value)} required />
        </div>
        <Button type="submit" disabled={createAnnouncement.isPending}>
          Create draft
        </Button>
      </form>

      {isLoading ? (
        <LoadingSpinner label="Loading announcements..." />
      ) : (
        <div className="space-y-4">
          {data?.data.map((announcement) => (
            <div key={announcement.uuid} className="rounded-xl border border-slate-200 bg-white p-5">
              <div className="flex items-start justify-between gap-3">
                <div>
                  <h2 className="font-semibold text-slate-900">{announcement.title}</h2>
                  <p className="mt-2 whitespace-pre-wrap text-sm text-slate-700">{announcement.body}</p>
                </div>
                <span className="text-xs text-slate-500">{announcement.published ? "Published" : "Draft"}</span>
              </div>
              <div className="mt-4 flex gap-2">
                {!announcement.published ? (
                  <Button onClick={() => publish.mutate(announcement.uuid)} disabled={publish.isPending}>
                    Publish
                  </Button>
                ) : null}
                <Button variant="danger" onClick={() => remove.mutate(announcement.uuid)} disabled={remove.isPending}>
                  Delete
                </Button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
