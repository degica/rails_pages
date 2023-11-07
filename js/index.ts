import { reactive } from 'vue';

//
// This error type can be read reactively in Vue templates.
//
//   <template>
//     <div class='error'>{{ $t(error.i18n) }}</div>
//   </template>
//
//   <script>
//     import { post, error } from 'rails-pages';
//
//     export default {
//       mounted() { post('wrong', { fail: true }); }
//     };
//   </script>
//
//
export type PageError = { i18n: string|null, lastResponse: Response|null };
export const error: PageError = reactive({
  i18n: null,
  lastResponse: null
});

//
// This lets you run server-side code wrapped in a 'get' ruby block.
//
//   # page.rb
//   RailsPages::Page.define '/mypage' do
//     data {{ test: 'test' }}
//
//     get 'more_info' do
//       render json: { hello: 'world' }
//     end
//   end
//
//   <!-- page.vue -->
//   <template>
//     <pre>{{ JSON.stringify(myinfo) }}</pre>
//   </template>
//
//   <script>
//     import { get } from 'rails-pages';
//
//     export default {
//       data: () => ({ myinfo: null }),
//
//       mounted() {
//         this.myinfo = await get('more_info');
//       }
//     };
//   </script>
//
export async function get(
  action: string,
  params?: Record<string, string>
): Promise<Object> {
  // Merge the current URL query with the input params.
  const query = new URLSearchParams(location.search);
  const paramsQuery = new URLSearchParams(params);
  paramsQuery.forEach((v, k) => {
    query.set(k, v);
  });

  // Action path is always at <current>/action/<action name>.
  const path = `${location.pathname}/action/${action}?${query.toString()}`;

  // Perform the fetch.
  const response = await fetch(path, {
    method: 'GET',
    mode: 'same-origin',
    cache: 'no-cache',
    credentials: 'same-origin',
    headers: { Accept: 'application/json' }
  });

  if (!response.ok) {
    requestFailed(response);
  }

  return response.json();
}

//
// This lets you run server-side code wrapped in a 'post' ruby block.
// It also handles CSRF protection.
//
//   # page.rb
//   RailsPages::Page.define '/mypage' do
//     data {{ test: 'test' }}
//
//     post 'create_comment' do
//       comment = Comment.create!(content: params[:content])
//       render json: comment
//     end
//   end
//
//   <!-- page.vue -->
//   <template>
//     <pre v-if="comment">{{ comment.content }}</pre>
//   </template>
//
//   <script>
//     import { post } from 'rails-pages';
//
//     export default {
//       data: () => ({ comment: null }),
//
//       mounted() {
//         this.comment = await post('create_comment', { content: 'hello' });
//       }
//     };
//   </script>
//
export async function post(
  action: string,
  params: Object
): Promise<Object> {
  // Rails generates meta tags with anti-CSRF information.
  // These tags may not exist when CSRF is disabled.
  const csrfParamMeta = document.getElementsByName('csrf-param')[0];
  const csrfTokenMeta = document.getElementsByName('csrf-token')[0];

  if ((csrfParamMeta instanceof HTMLMetaElement) && (csrfTokenMeta instanceof HTMLMetaElement)) {
    // Add the anti-CSRF token to our query.
    params[csrfParamMeta.content] = csrfTokenMeta.content;
  } else {
    console.warn('CSRF token meta tags not found');
  }

  // Make a POST to the action endpoint with the query as JSON.
  const response = await fetch(`${location.pathname}/action/${action}`, {
    method: 'POST',
    mode: 'same-origin',
    cache: 'no-cache',
    credentials: 'same-origin',
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json'
    },
    body: JSON.stringify(params)
  });

  if (!response.ok) {
    requestFailed(response);
  }

  return response.json();
}

//
// Internal function for handling HTTP errors.
//
// To keep the API simple, we throw when we receive anything other than
// HTTP 200.
//
// To handle such errors, the developer can import the 'error' object above,
// and use its reactive properties to easily render error messages as they
// come up.
//
function requestFailed(response: Response) {
  const errorType = response.statusText
    .toLowerCase()
    .replace(/\s+/g, '_');

  error.lastResponse = response;
  error.i18n = `error.${errorType}`;

  throw error;
}
