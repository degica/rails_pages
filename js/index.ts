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
    console.error(response);
    throw 'Request failed...';
  }

  return response.json();
}

export async function post(
  action: string,
  params: Object
): Promise<Object> {
  // Rails generates meta tags with anti-CSRF information.
  const csrfParamMeta = document.getElementsByName('csrf-param')[0];
  const csrfTokenMeta = document.getElementsByName('csrf-token')[0];

  if (!(csrfParamMeta instanceof HTMLMetaElement)) {
    console.error(csrfParamMeta);
    throw 'CSRF param unspecified';
  }
  if (!(csrfTokenMeta instanceof HTMLMetaElement)) {
    console.error(csrfTokenMeta);
    throw 'CSRF param unspecified';
  }

  // Add the anti-CSRF token to our query.
  params[csrfParamMeta.content] = csrfTokenMeta.content;

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
    console.error(response);
    throw 'Request failed...';
  }

  return response.json();
}
